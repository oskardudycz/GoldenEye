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

    $.ajax("https://localhost:44300/api/Task", {
        dataType: "json",
        data: { TaskName: taskname, Number: number, Date: date, Progress: progress, Type: type, IsInternal: isInternal, Description: desc, Amount: amount, Color: color },
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

ko.components.register("add-new-task", {
    viewModel: AddTaskModel,
    template: { element: "Dodaj" }
});