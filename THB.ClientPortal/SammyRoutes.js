var routing = $.sammy(function () {

    this.element_selector = "body";

    $(document).ready(function () {
        routing.run("#Zlecenia");
    });

    this.get("#:view", function () {
        if (this.params.view === "Dodaj")
            app.current("add-new-task");
        else if (this.params.view === "Zlecenia")
            app.current("tasks-list");
    });

    this.get('#/Zlecenia/:Number', function (context) {
        this.item = this.items[this.params['Number']];
        if (!this.item) { return this.notFound(); }
            app.current('task-details');
    });
});