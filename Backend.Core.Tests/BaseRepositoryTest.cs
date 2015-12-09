using System;
using System.Text;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using FizzWare.NBuilder;
using SharpTestsEx;
using Backend.Business.Entities;
using Backend.Business.Context;
using Backend.Business.Repository;
using Shared.Core.Security;

namespace Backend.Core.Tests
{
    [TestClass]
    public class BaseRepositoryTest
    {
        [Ignore]
        [TestMethod]
        public void AddTask()
        {
            var dbset = new Mock<IDbSet<TaskEntity>>();
            var tasklist = new List<TaskEntity>()
            {
                new TaskEntity()
                {
                    Name = "repair",
                    Number = "1",
                    Progress = 50,
                    Id = 1
                },
                new TaskEntity()
                {
                    Name = "painting",
                    Number = "2",
                    Progress = 30,
                    Id = 2
                }
            }.AsQueryable();

            dbset.Setup(m => m.Provider).Returns(tasklist.Provider);
            dbset.Setup(m => m.Expression).Returns(tasklist.Expression);
            dbset.Setup(m => m.ElementType).Returns(tasklist.ElementType);
            dbset.Setup(m => m.GetEnumerator()).Returns(tasklist.GetEnumerator());

            var mockDbContext = new Mock<ITHBContext>();
            mockDbContext
                .Setup(x => x.Tasks)
                .Returns(dbset.Object);

            var repository = new TaskRepository(mockDbContext.Object, new Mock<IUserInfoProvider>().Object);

            repository.Add(new TaskEntity()
                {
                    Name = "sleepwalking",
                    Number = "3",
                    Progress = 70,
                    Id = 3
                });
            repository.SaveChanges();

            var count = tasklist.Count();
            //Assert.AreEqual(3, count);
            var obj = repository.GetById(3);
            Assert.IsNotNull(obj);
        }

        [TestMethod]
        public void CheckIfTaskExists()
        {
            var tasklist = new List<TaskEntity>
            {
                new TaskEntity() { Id = 1, Name = "daydreaming" },
                new TaskEntity() { Id = 2, Name = "whistling" },
                new TaskEntity() { Id = 3, Name = "dancing" }
            };

            var repository = new Mock<ITaskRepository>();

            repository.Setup(x => x.GetById(It.IsAny<int>()))
                .Returns((int i) => tasklist.Single(x => x.Id == i));

            var testRepository = repository.Object;

            var task = testRepository.GetById(2);

            Assert.IsNotNull(task);
            Assert.AreEqual(task.Id, 2);
            Assert.AreEqual(task.Name, "whistling");
        }

        [TestMethod]
        public void DeleteTask()
        {
            var tasklist = new List<TaskEntity>
            {
                new TaskEntity() { Id = 1, Name = "daydreaming" },
                new TaskEntity() { Id = 2, Name = "whistling" },
                new TaskEntity() { Id = 3, Name = "dancing" }
            };

            var repository = new Mock<ITaskRepository>();

            int id = 3;

            repository.Setup(x => x.Delete(It.IsAny<TaskEntity>())).Callback(new Action<TaskEntity>(x =>
            {
                var i = tasklist.FindIndex(q => q.Id.Equals(id));
                tasklist.RemoveAt(i);
            }));

            var testRepository = repository.Object;

            testRepository.Delete(id);
            Assert.IsNull(testRepository.GetById(3));
        }
    }
}
