window.config = {
    routerBasename: '/',
    extensions: [],
    modes: [],
    showStudyList: true,
    dataSources: [
      {
        namespace: '@ohif/extension-default.dataSourcesModule.dicomweb',
        sourceName: 'dicomweb',
        configuration: {
          friendlyName: 'DCM4CHEE DICOM Web',
          name: 'DCM4CHEE',
          wadoUriRoot: 'http://10.0.0.10:8080/dcm4chee-arc/aets/DCM4CHEE/wado',
          qidoRoot: 'http://10.0.0.10:8080/dcm4chee-arc/aets/DCM4CHEE/rs',
          wadoRoot: 'http://10.0.0.10:8080/dcm4chee-arc/aets/DCM4CHEE/rs',
          qidoSupportsIncludeField: true,
          imageRendering: 'wadors',
          thumbnailRendering: 'wadors',
          enableStudyLazyLoad: true,
          supportsFuzzyMatching: true,
          supportsReject: true,
          requestOptions: {
            requestCredentials: 'omit'
          }
        }
      }
    ],
    defaultDataSourceName: 'dicomweb',
    hotkeys: [],
    cornerstoneExtensionConfig: {},
    investigationalUseDialog: {
      option: 'never'
    }
  };
  