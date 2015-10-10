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
});