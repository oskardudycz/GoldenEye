var DEBUG = false;//true;

var app = (function () {
    function init() {
        routing.run();
        ko.applyBindings();
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