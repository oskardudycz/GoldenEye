var app = $.sammy(function () {

    this.element_selector = 'body';

    $(document).ready(function () {
        app.run('#Home');
    });

    this.get('#:view', function () {
        vm.currentView(this.params.view);
    });

});