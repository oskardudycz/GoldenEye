using System;
using System.Linq;
using Backend.Business.Context;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SharpTestsEx;

namespace Backend.Business.Tests.Modeler
{
    [TestClass]
    public class SaveTaskTests
    {
        [TestMethod]
        public void GivenFilledTask_WhenSaveTaskMethodIsBeingCalled_ThenSavesProperlyAndReturnsSameTask()
        {
            using (var db = new ModelerContext())
            {
                using (db.BeginTransaction())
                {
                    //GIVEN
                    var customer = db.Customers.First();
                    var taskType = db.TaskTypes.First();

                    var task = new Task
                    {
                        Name = "test",
                        ModificationDate = DateTime.Now,
                        PlannedStartDate = DateTime.Now,
                        PlannedEndDate = DateTime.Now,
                        PlanningDate = DateTime.Now,
                        Number = "123",
                        Date = DateTime.Now,
                        Description = "test",
                        Color = 123,
                        CustomerColor = 234,
                        Amount = 3,
                        IsInternal = false,
                        PlannedTime = 3,

                        CustomerId = customer.Id,
                        TypeId = taskType.Id
                    };

                    //WHEN
                    var insertedId = db.SaveTask(task);
                   
                    //THEN
                    insertedId.Should().Be.GreaterThan(0);


                    var taskFromDb = db.Tasks.Find(insertedId);

                    taskFromDb.Should().Not.Be.Null();
                    taskFromDb.Id.Should().Be.EqualTo(taskFromDb.Id);
                    taskFromDb.PlannedStartDate.Should().Be.EqualTo(task.PlannedStartDate);
                    taskFromDb.PlannedEndDate.Should().Be.EqualTo(task.PlannedEndDate);
                    taskFromDb.PlanningDate.Should().Be.EqualTo(task.PlanningDate);
                    taskFromDb.Number.Should().Be.EqualTo(task.Number);
                    taskFromDb.Date.Should().Be.EqualTo(task.Date);
                    taskFromDb.Description.Should().Be.EqualTo(task.Description);

                    taskFromDb.Color.Should().Be.EqualTo(task.Color);
                    taskFromDb.CustomerColor.Should().Be.EqualTo(task.CustomerColor);
                    taskFromDb.Amount.Should().Be.EqualTo(task.Amount);
                    taskFromDb.IsInternal.Should().Be.EqualTo(task.IsInternal);
                    taskFromDb.PlannedTime.Should().Be.EqualTo(task.PlannedTime);
                    taskFromDb.CustomerId.Should().Be.EqualTo(task.CustomerId);
                    taskFromDb.TypeId.Should().Be.EqualTo(task.Id);

                    taskFromDb.Name += "testtest";

                    db.SaveTask(task);

                    var tes = db.Tasks.ToList();
                }
            }
        }
    }
}
