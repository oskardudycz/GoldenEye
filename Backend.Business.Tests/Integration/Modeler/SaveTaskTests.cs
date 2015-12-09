using System;
using System.Linq;
using Backend.Business.Context;
using Backend.Business.Entities;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Shared.Core.Extensions;
using SharpTestsEx;

namespace Backend.Business.Tests.Modeler
{
    [TestClass]
    public class SaveTaskTests
    {
        [Ignore]
        [TestMethod]
        public void GivenFilledTask_WhenSaveTaskMethodIsBeingCalled_ThenSavesProperlyAndReturnsSameTask()
        {
            using (var db = new THBContext())
            {
                using (db.BeginTransaction())
                {
                    //GIVEN
                    var customer = db.Customers.First();
                    var taskType = db.TaskTypes.First();

                    var task = new TaskEntity
                    {
                        Name = "test",
                        ModificationDate = DateTime.Now,
                        PlannedStartDate = DateTime.Now,
                        PlannedEndDate = DateTime.Now,
                        PlanningDate = DateTime.Now,
                        Number = "test",
                        Date = DateTime.Now,
                        Description = "test",
                        Color = 3,
                        CustomerColor = 3,
                        Amount = 3,
                        IsInternal = true,
                        PlannedTime = 3,

                        CustomerId = customer.Id,
                        TypeId = taskType.Id,
                        ModificationBy = "THBAdmina"
                    };

                    var insertedTask = TestInsert(db, task);

                    TestUpdate(db, insertedTask);
                }
            }
        }

        private static TaskEntity TestInsert(THBContext db, TaskEntity task)
        {
            var previousTasksCount = db.Tasks.Count();

            //WHEN
            var insertedId = db.AddOrUpdateTask(task);

            //THEN
            insertedId.Should().Be.GreaterThan(0);
            db.Tasks.Count().Should().Be.EqualTo(previousTasksCount + 1);

            var insertedTask = db.Tasks.Find(insertedId);

            CheckIfAreTheSame(task, insertedTask);

            return insertedTask;
        }

        private static void TestUpdate(THBContext db, TaskEntity task)
        {
            var customer = db.Customers.OrderBy(el => el.Id).Skip(1).First();
            var taskType = db.TaskTypes.OrderBy(el => el.Id).Skip(1).First();

            task.PlannedStartDate = DateTime.Now;
            task.PlannedEndDate = DateTime.Now;
            task.PlanningDate = DateTime.Now;
            task.Number = "testtest";
            task.Date = DateTime.Now;
            task.Description = "testtest";

            task.Color = 9;
            task.CustomerColor = 9;
            task.Amount = 9;
            task.IsInternal = false;
            task.PlannedTime = 9;
            task.CustomerId = customer.Id;
            task.TypeId = taskType.Id;

            //WHEN
            var insertedId = db.AddOrUpdateTask(task);

            //THEN
            insertedId.Should().Be.GreaterThan(0);

            var updatedTask = db.Tasks.Find(insertedId);

            CheckIfAreTheSame(task, updatedTask);
        }

        private static void CheckIfAreTheSame(TaskEntity task, TaskEntity insertedTask)
        {
            insertedTask.Should().Not.Be.Null();
            insertedTask.Id.Should().Be.EqualTo(insertedTask.Id);
            insertedTask.PlannedStartDate.Truncate(TimeSpan.TicksPerSecond).Should().Be.EqualTo(task.PlannedStartDate.Truncate(TimeSpan.TicksPerSecond));
            insertedTask.PlannedEndDate.Truncate(TimeSpan.TicksPerSecond).Should().Be.EqualTo(task.PlannedEndDate.Truncate(TimeSpan.TicksPerSecond));
            insertedTask.PlanningDate.Truncate(TimeSpan.TicksPerSecond).Should().Be.EqualTo(task.PlanningDate.Truncate(TimeSpan.TicksPerSecond));
            insertedTask.Number.Should().Be.EqualTo(task.Number);
            insertedTask.Date.Truncate(TimeSpan.TicksPerSecond).Should().Be.EqualTo(task.Date.Truncate(TimeSpan.TicksPerSecond));
            insertedTask.Description.Should().Be.EqualTo(task.Description);

            insertedTask.Color.Should().Be.EqualTo(task.Color);
            insertedTask.CustomerColor.Should().Be.EqualTo(task.CustomerColor);
            insertedTask.Amount.Should().Be.EqualTo(task.Amount);
            insertedTask.IsInternal.Should().Be.EqualTo(task.IsInternal);
            insertedTask.PlannedTime.Should().Be.EqualTo(task.PlannedTime);
            insertedTask.CustomerId.Should().Be.EqualTo(task.CustomerId);
            insertedTask.TypeId.Should().Be.EqualTo(task.TypeId);
        }
    }
}
