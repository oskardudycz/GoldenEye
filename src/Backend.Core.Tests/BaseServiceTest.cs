using System;
using System.Collections.Generic;
using System.Linq;
using AutoMapper;
using FizzWare.NBuilder;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Repository;
using GoldenEye.Backend.Business.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace GoldenEye.Backend.Core.Tests
{
    [TestClass]
    public class BaseServiceTest
    {
        private static IList<TaskEntity> objects;
        private static int size;
        [ClassInitialize]
        public static void MapperInit(TestContext context)
        {
            //AutoMapperConfig.RegisterMappings();
        }
        [TestInitialize]
        public void PopulateDatabase()
        {
            size = 3;
            objects = Builder<TaskEntity>.CreateListOfSize(size).Build();
        }

        [Ignore]
        [TestMethod]
        public void GetByIdReturnTask()
        {
            var repository = new Mock<ITaskRepository>();
            const int id = 2;

            objects[1] = Builder<TaskEntity>.CreateNew()
                .With(x => x.Name = "repair")
                .With(x => x.Number = "1")
                .With(x => x.Progress = 60)
                .Build();
            objects[1].Id = id;

            repository.Setup(x => x.GetById(id, It.IsAny<bool>())).Returns(objects[1]);

            var service = new TaskRestService(repository.Object);

            var task = (service.Get(id)).Result;

            Mapper.AssertConfigurationIsValid();
            repository.Verify(x => x.GetById(It.IsAny<Int32>(), It.IsAny<bool>()), Times.Exactly(1));
            Assert.IsNotNull(task);
            Assert.AreEqual("repair", task.Name);
            Assert.AreEqual(1, task.Number);
            Assert.AreEqual(60, task.Progress);
        }

        [TestMethod]
        public void Add()
        {
            var repository = new Mock<ITaskRepository>();

            const int id = 2;

            objects[1] = Builder<TaskEntity>.CreateNew()
                .With(x => x.Name = "repair")
                .With(x => x.Number = "1")
                .With(x => x.Progress = 60)
                .Build();

            objects[1].Id = id;

            var service = new TaskRestService(repository.Object);

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
                var element = objects.FirstOrDefault(q => q.Id.Equals(id));
                objects.Remove(element);
            }));

            var service = new TaskRestService(repository.Object);

            service.Delete(id);

            Mapper.AssertConfigurationIsValid();
            objects.Count.Equals(2);
        }
    }
}
