angular.module('app').factory('ToasterService', (toaster) => {
  
    
    return {
        showToast: (type, title, body, timeout) => {
            console.log('ToasterService');
            toaster.pop({type, title, body, timeout});
        },
        showToast: (type, title, body) => {
            console.log('ToasterService');
            toaster.pop({type, title, body, timeout:2000});
        },
        showSuccess: (title, body) => {
            console.log('ToasterService');
            toaster.pop({ type: 'success', title, body, timeout: 2000 });
        },
        showError: (title, body) => {
            console.log('ToasterService');
            toaster.pop({type: 'error', title, body, timeout: 2000 });
        }
    };
});