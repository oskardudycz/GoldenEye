var routing = $.sammy(function () {

    this.element_selector = 'body';

    $(document).ready(function () {
        routing.run('#Zlecenia');
    });

    this.get('#:view', function () {
        app.changeViewModel();
        //if (this.params.view == "Dodaj")
       //     app.viewModel = ViewModelLocator.Get(common.getPath());
       // else if (this.params.view == "Zlecenia")
        //    ;

        //vm.currentView(this.params.view);
    });
});