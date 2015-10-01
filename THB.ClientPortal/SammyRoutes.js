var app = $.sammy(function () {

    this.element_selector = 'body';

    $(document).ready(function () {
        app.run('#Zlecenia');
    });

    this.get('#:view', function () {
        vm.currentView(this.params.view);
    });

});