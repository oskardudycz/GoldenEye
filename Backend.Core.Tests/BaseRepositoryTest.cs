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

namespace Backend.Core.Tests
{
    [TestClass]
    public class BaseRepositoryTest
    {
        [TestMethod]
        public void AddTask()
        {
            var dbset = new Mock<IDbSet<TaskEntity>>();
            var tasklist = new List<TaskEntity>()
            {
                new TaskEntity()
                {
                    TaskName = "repair",
                    Number = 1,
                    Progress = 50,
                    Id = 1
                },
                new TaskEntity()
                {
                    TaskName = "painting",
                    Number = 2,
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

            var repository = new TaskRepository(mockDbContext.Object);

            repository.Add(new TaskEntity()
                {
                    TaskName = "sleepwalking",
                    Number = 3,
                    Progress = 70,
                    Id = 3
                });

            var count = tasklist.Count();
            //Assert.AreEqual(3, count);
            var obj = repository.GetById(2);
            Assert.IsNotNull(obj);
        }

        [TestMethod]
        public void DeleteTask()
        {
            var dbset = new Mock<IDbSet<TaskEntity>>();
        }
    }
}
