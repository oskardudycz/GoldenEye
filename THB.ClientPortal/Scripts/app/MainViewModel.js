var AddTaskModel = function () {
    var self = this;

    self.TaskName = ko.observable();
    self.Number = ko.observable();
    self.Date = ko.observable();
    self.Type = ko.observable();
    self.IsInternal = ko.observable();
    self.Amount = ko.observable();
    self.Time = ko.observable();
    self.StartDate = ko.observable();
    self.PlanDate = ko.observable();
    self.EndDate = ko.observable();
    self.Description = ko.observable();
    self.Color = ko.observable();
    self.Progress = ko.observable();

    self.Id = ko.observable();

    self.currentView = ko.observable();
    self.views = ko.observableArray(["Zlecenia", "Dodaj"]);

    self.viewModelName = "Dodaj";
    self.viewName = "Dodaj";
}

AddTaskModel.prototype.save = function () {
    var self = this;
    var taskname = self.TaskName();
    var number = self.Number();
    var date = self.Date();
    var progress = self.Progress();
    var type = self.Type();
    var amount = self.Amount();
    var isInternal = self.IsInternal();
    var desc = self.Description();
    var color = self.Color();

    $.ajax("http://localhost:35761/api/Task", {
        dataType: "json",
        data:  { TaskName: taskname, Number: number, Date: date, Progress: progress, Type: type, IsInternal: isInternal, Description: desc, Amount: amount, Color: color },
        type: "PUT",
        success: function (data) {
            alert("Added successfully!");
        }
    });
};

AddTaskModel.prototype.addTask = function () {
    var self = this;
    self.save();
};

var TaskListModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    self.loadTaskList = function () {
        $.getJSON("http://localhost:35761/api/task", function (data) {
            var newTasks = ko.mapping.fromJS(data);
            self.tasklist(newTasks());
        });
    }

    self.loadTaskList();
    /*
    if (!tasklist)
        tasklist = [
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ];
        */
    self.save = function (form) {
        ko.utils.postJson($("form")[0], self.tasklist);
    };

    self.viewModelName = "Zlecenia";
    self.viewName = "Zlecenia";
};

function MainViewModel() {
    var self = this;

    app.mainViewModel = self;

    self.current = ko.observable();
    self.AddTaskModel = new AddTaskModel();
    self.TaskListModel = new TaskListModel();
}


function DetailViewModel(id) {
    var self = this;
    self.Id = ko.observable(id);

    self.TaskName = ko.observable();
    self.Number = ko.observable();
    self.Date = ko.observable();
    self.Type = ko.observable();
    self.IsInternal = ko.observable();
    self.Amount = ko.observable();
    self.Time = ko.observable();
    self.StartDate = ko.observable();
    self.PlanDate = ko.observable();
    self.EndDate = ko.observable();
    self.Description = ko.observable();
    self.Color = ko.observable();
    self.Progress = ko.observable();

    self.getTask = function (id) {
        $.ajax({
            url: 'http://localhost:35761/api/task/' + id,
            type: "GET",
            dataType: "json",
            success: function (data) {
                self.TaskName(data.TaskName);
                self.Number(data.Number);
                self.Date(data.Date);
                self.Type(data.Type);
                self.IsInternal(data.IsInternal);
                self.Amount(data.Amount);
                self.Time(data.Time);
                self.StartDate(data.StartDate);
                self.PlanDate(data.PlanDate);
                self.EndDate(data.EndDate);
                self.Description(data.Description);
                self.Color(data.Color);
                self.Progress(data.Progress);
            }
        });
    };

    self.viewModelName = "Detale";
    self.viewName = "Detale";

}

ko.components.register("main", {
    viewModel: MainViewModel,
    template: { element: "main-view" }
});

ko.components.register("tasks-list", {
    viewModel: TaskListModel,
    template: { element: "Zlecenia" }
});

ko.components.register("add-new-task", {
    viewModel: AddTaskModel,
    template: { element: "Dodaj" }
});

ko.components.register("task-details", {
    viewModel: {
        createViewModel: function (params, componentInfo) {
            var viewModel = new DetailViewModel(params);

            viewModel.getTask(viewModel.Id());

            return viewModel;
        }
    },
    template: { element: "Detale" }
});