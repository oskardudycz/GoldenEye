var DEBUG = false;//true;

var app = (function () {
    function init() {
        //this.viewModel = ko.observable(ViewModelLocator.Get(common.getPath()));

        //if (this.viewModel) {
        //    Sammy().run();
        //    ko.applyBindings(this.viewModel(), $('#viewContainer')[0]);
        //}
        //else {
        //    console.log('Warning: No view model was defined');
        //}
        Sammy().run();
        ko.applyBindings();
    }

    ko.unapplyBindings = function ($node, remove) {
        // unbind events
        $node.find("*").each(function () {
            $(this).unbind();
        });

        // Remove KO subscriptions and references
        if (remove) {
            ko.removeNode($node[0]);
        } else {
            ko.cleanNode($node[0]);
        }
    };

    function changeViewModel() {
        ko.unapplyBindings($('#viewContainer'));
        app.viewModel(ViewModelLocator.Get(common.getPath()));
        ko.applyBindings(app.viewModel(), $('#viewContainer')[0]);
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