using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Backend.Core.Service;
using Backend.Business.Entities;
using Shared.Business.Contracts;
using Backend.Business.Services;
using Backend.Business.Repository;
using Moq;
using FizzWare.NBuilder;
using AutoMapper;
using Frontend.Web.App_Start;

namespace Backend.Core.Tests
{
    [TestClass]
    public class BaseServiceTest
    {
        private static List<TaskEntity> objects;
        private static int size;
        [ClassInitialize]
        public static void MapperInit(TestContext context)
        {
            AutoMapperConfig.RegisterMappings();
        }
        [TestInitialize]
        public void PopulateDatabase()
        {
            size = 3;
            objects = (List<TaskEntity>)(Builder<TaskEntity>.CreateListOfSize(size).Build());
        }

        [TestMethod]
        public void GetByIdReturnTask()
        {
            var repository = new Mock<ITaskRepository>();
            const int id = 2;

            objects[1] = Builder<TaskEntity>.CreateNew()
                .With(x => x.TaskName = "repair")
                .With(x => x.Number = 1)
                .With(x => x.Progress = 60)
                .Build();
            objects[1].Id = id;

            repository.Setup(x => x.GetById(id)).Returns(objects[1]);

            var service = new TaskService(repository.Object);

            var task = service.GetById(id);

            Mapper.AssertConfigurationIsValid();
            repository.Verify(x => x.GetById(It.IsAny<Int32>()), Times.Exactly(1));
            Assert.IsNotNull(task);
            Assert.AreEqual("repair", task.TaskName);
            Assert.AreEqual(1, task.Number);
            Assert.AreEqual(60, task.Progress);
        }

        [TestMethod]
        public void Add()
        {
            var repository = new Mock<ITaskRepository>();

            const int id = 2;

            objects[1] = Builder<TaskEntity>.CreateNew()
                .With(x => x.TaskName = "repair")
                .With(x => x.Number = 1)
                .With(x => x.Progress = 60)
                .Build();
            objects[1].Id = id;

            var service = new TaskService(repository.Object);

            //service.Add();

        }

        [TestMethod]
        public void Remove()
        {
            var repository = new Mock<ITaskRepository>();
            int id = 2;
            objects[1].Id = id;
            repository.Setup(x => x.Delete(It.IsAny<TaskEntity>())).Callback(new Action<TaskEntity>(x =>
            {
                var i = objects.FindIndex(q => q.Id.Equals(id));
                objects.RemoveAt(i);
            }));

            var service = new TaskService(repository.Object);

            service.Remove(id);

            Mapper.AssertConfigurationIsValid();
            objects.Count.Equals(2);
        }
    }
}
