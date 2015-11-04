var routing = $.sammy(function () {

    this.element_selector = "body";

    $(document).ready(function () {
        if(authManager.getToken())
            routing.run("#Zlecenia");
        else
            routing.run("#Login");
    });
    
    this.get("#:view", function () {
        if (!authManager.getToken() || this.params.view === "Login")
            app.current("user-login-register");
        else if (this.params.view === "Dodaj")
            app.current("add-new-task");
        else if (this.params.view === "Zlecenia")
            app.current("tasks-list");
        else if (this.params.view === "Login")
            app.current("user-login-register");
    });

    this.get("#:view/:id", function () {
        app.params(this.params.id);

        if (this.params.view === "Detale")
            app.current("task-details");
    });

});