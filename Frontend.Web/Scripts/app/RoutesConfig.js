var routing = $.sammy(function () {
    var mappings = [];

    var loginComponentName;

    var defaultViewName;

    var changeRoute = function (view, params) {
        app.params(params);

        if (!authManager.getToken())
            app.current(loginComponentName);
        else {
            var matched = mappings.filter(function (el) { return el.view === view; });
            if (!matched || matched.length === 0)
                throw "RoutesConfig - component for view: " + view + " not found!";

            var componentName = matched[0].component;

            app.current(componentName);
        }

    }

    this.get("#:view/:id", function () {
        changeRoute(this.params.view, this.params.id);
    });

    this.get("#:view", function () {
        changeRoute(this.params.view);
    });

    this.get("", function () {
        changeRoute(defaultViewName);
    });
    
    this.init = function (options) {
        loginComponentName = options.loginComponentName || "login-nc";
        defaultViewName = options.defaultViewName;

        mappings = options.mappings;
    }

});

routing.init({
    loginComponentName: "login-nc",
    defaultViewName: "Zlecenia",
    mappings: [
        { view: "Login", component: "login-nc" },
        { view: "Zlecenia", component: "TaskList-nc" },
        { view: "Dodaj", component: "AddTask-nc" },
        { view: "Detale", component: "TaskDetail-nc" }
    ]
});