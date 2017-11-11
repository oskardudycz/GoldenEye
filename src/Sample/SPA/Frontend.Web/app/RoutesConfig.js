routing.init({
    loginComponentName: "login-nc",
    defaultViewName: "zadania",
    mappings: [
        { view: "Login", component: "login-nc" },
        { view: "zadania", component: "TaskList-nc" },
        { view: "Dodaj", component: "AddTask-nc" },
        { view: "Detale", component: "TaskDetail-nc" }
    ]
});