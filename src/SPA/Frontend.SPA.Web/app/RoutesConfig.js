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