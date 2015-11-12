var routing = $.sammy(function () {

    this.element_selector = "body";

    /*
    this.get("#:view", function () {
        if (!authManager.getToken() || this.params.view === "Login")
            app.current("login-nc");
        else if (this.params.view === "Dodaj")
            app.current("AddTask-nc");
        else if (this.params.view === 'Zlecenia')
            app.current("TaskList-nc");
    });
    */
    this.changeRoute = function (view, component) {
        routing.get(view, function () {
            if(authManager.getToken())
                app.current(component);
            else
                app.current("login-nc");
        });
    }

    this.get("#:view/:id", function () {
        app.params(this.params.id);

        if (this.params.view === "Detale")
            app.current("TaskDetail-nc");
    });
    /*
    this.get('', function () {
        if (!authManager.getToken())
            app.current("login-nc");
        else
            app.current("TaskList-nc");
    });
    */

});

routing.changeRoute("#Zlecenia", "TaskList-nc");
routing.changeRoute("#Dodaj", "AddTask-nc");
routing.changeRoute("", "TaskList-nc");