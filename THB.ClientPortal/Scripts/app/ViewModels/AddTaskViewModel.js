var AddTaskViewModel = function () {
    var self = this;

    self.TaskName = ko.observable().extend({ required: true });
    self.Number = ko.observable().extend({
        required: true,
        number: true
    });
    self.Date = ko.observable();
   // self.Type = ko.observableArray(['Typ1', 'Typ2', 'Typ3'])
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

AddTaskViewModel.prototype.addTask = function () {
    var self = this;
    service.addTask(self);
};

ko.components.register("add-new-task", {
    viewModel: AddTaskViewModel,
    template: { element: "Dodaj" }
});