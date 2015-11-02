var DEBUG = false;//true;

var app = (function () {
    function init() {
        Sammy().run();
        ko.applyBindings();
    }

    return {

        viewModel: undefined,

        Init: init,

        current: ko.observable(),
        params: ko.observable()
    };

})();
$(function () {
    app.Init();
});