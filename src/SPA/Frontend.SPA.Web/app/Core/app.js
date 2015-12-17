var DEBUG = false;//true;

var app = (function () {
    function init() {
        if(componentsConfig)
            componentsConfig.init();

        routing.run();
        ko.applyBindings();

        ko.validation.locale('pl-PL');
        ko.validation.init({
            errorMessageClass: 'error-messages'
        });
    }

    return {

        viewModel: undefined,

        Init: init,

        current: ko.observable(),
        params: ko.observable()
    };

})();
$(document).ready(function () {
    app.Init();
});