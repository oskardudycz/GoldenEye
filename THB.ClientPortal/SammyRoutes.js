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

    this.get("#:view/:id", function () {
        app.params(this.params.id);

        if (this.params.view === "Detale")
            app.current("task-details");
    });



    /*
    this.get('#Zlecenia/:number', function (context) {
        this.item = this.items[this.params['number']];
        if (!this.item)
            return this.notFound();
        else
            app.current('task-details');
       // self.getTask(this.params.number);
       // if task with number exists, return that task and show in task-details component
    });*/
});