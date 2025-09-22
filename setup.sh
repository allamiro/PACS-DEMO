#!/bin/bash

# DCM4CHEE PACS Setup Script
# ==========================

set -e

echo "🏥 DCM4CHEE PACS Setup Script"
echo "============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DATA_DIR="./data"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}📁 Creating data directories...${NC}"

# Create data directories
mkdir -p "${DATA_DIR}/ldap"
mkdir -p "${DATA_DIR}/slapd.d"
mkdir -p "${DATA_DIR}/db"
mkdir -p "${DATA_DIR}/wildfly"
mkdir -p "${DATA_DIR}/storage"

echo -e "${GREEN}✅ Data directories created successfully${NC}"

# Check if timezone file exists
echo -e "${BLUE}🕐 Checking timezone configuration...${NC}"
if [ ! -f /etc/timezone ]; then
    echo -e "${YELLOW}⚠️  /etc/timezone not found. Creating with system timezone...${NC}"
    if command -v timedatectl &> /dev/null; then
        TIMEZONE=$(timedatectl show --property=Timezone --value)
        echo "$TIMEZONE" | sudo tee /etc/timezone > /dev/null
        echo -e "${GREEN}✅ Created /etc/timezone with: $TIMEZONE${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not determine timezone. Please create /etc/timezone manually${NC}"
        echo -e "${YELLOW}   Example: echo 'Europe/London' | sudo tee /etc/timezone${NC}"
    fi
else
    TIMEZONE=$(cat /etc/timezone)
    echo -e "${GREEN}✅ Timezone configured: $TIMEZONE${NC}"
fi

# Optional: Create system users (requires sudo)
echo -e "${BLUE}👥 System users setup (optional)...${NC}"
read -p "Do you want to create system users for better file ownership? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔐 Creating system users (requires sudo)...${NC}"
    
    # Create groups and users
    sudo groupadd -r slapd-dcm4chee --gid=1021 2>/dev/null || echo "Group slapd-dcm4chee already exists"
    sudo useradd -r -g slapd-dcm4chee --uid=1021 slapd-dcm4chee 2>/dev/null || echo "User slapd-dcm4chee already exists"
    
    sudo groupadd -r postgres-dcm4chee --gid=999 2>/dev/null || echo "Group postgres-dcm4chee already exists"
    sudo useradd -r -g postgres-dcm4chee --uid=999 postgres-dcm4chee 2>/dev/null || echo "User postgres-dcm4chee already exists"
    
    sudo groupadd -r dcm4chee-arc --gid=1023 2>/dev/null || echo "Group dcm4chee-arc already exists"
    sudo useradd -r -g dcm4chee-arc --uid=1023 dcm4chee-arc 2>/dev/null || echo "User dcm4chee-arc already exists"
    
    # Set ownership
    sudo chown -R 1021:1021 "${DATA_DIR}/ldap" "${DATA_DIR}/slapd.d"
    sudo chown -R 999:999 "${DATA_DIR}/db"
    sudo chown -R 1023:1023 "${DATA_DIR}/wildfly" "${DATA_DIR}/storage"
    
    echo -e "${GREEN}✅ System users created and ownership set${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping system users creation${NC}"
    echo -e "${YELLOW}   File ownership will show as numerical IDs${NC}"
fi

# Check Docker and Docker Compose
echo -e "${BLUE}🐳 Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo -e "${YELLOW}   Please install Docker first: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo -e "${YELLOW}   Please install Docker Compose first${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are available${NC}"

# Check if .env file exists
if [ ! -f "${SCRIPT_DIR}/.env" ]; then
    echo -e "${BLUE}📝 Creating .env file from docker-compose.env...${NC}"
    cp "${SCRIPT_DIR}/docker-compose.env" "${SCRIPT_DIR}/.env"
    echo -e "${GREEN}✅ .env file created${NC}"
    echo -e "${YELLOW}   You can customize settings in .env file${NC}"
fi

echo
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Review and customize settings in ${YELLOW}.env${NC} file"
echo -e "2. Start the services: ${YELLOW}docker-compose up -d${NC}"
echo -e "3. Check logs: ${YELLOW}docker-compose logs -f${NC}"
echo -e "4. Access web interface: ${YELLOW}http://localhost:8080/dcm4chee-arc/ui2${NC}"
echo
echo -e "${BLUE}Useful commands:${NC}"
echo -e "• Start services: ${YELLOW}docker-compose up -d${NC}"
echo -e "• Stop services: ${YELLOW}docker-compose stop${NC}"
echo -e "• View logs: ${YELLOW}docker-compose logs -f [service]${NC}"
echo -e "• Remove everything: ${YELLOW}docker-compose down -v${NC}"
echo
echo -e "${YELLOW}⚠️  Important: Make sure to backup the data directory regularly!${NC}"
