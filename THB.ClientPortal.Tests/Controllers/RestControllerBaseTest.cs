using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Frontend.Web.Controllers;
using Frontend.Web.App_Start;
using Shared.Business.Contracts;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Backend.Core.Service;
using Moq;
using FizzWare.NBuilder;

namespace THB.ClientPortal.Tests.Controllers
{
    [TestClass]
    public class RestControllerBaseTest
    {
        private static int size;
        [ClassInitialize]
        public static void MapperInit(TestContext context)
        {
            AutoMapperConfig.RegisterMappings();
        }
        [TestMethod]
        public void Get()
        {
            var service = new Mock<IRestService<TaskDTO>>();
            var dto = new Mock<TaskDTO>();
            //var repository = new Mock<ITaskRepository>();

            //var controller = new RestControllerBase(service.Object);
        }

        [TestMethod]
        public void Put()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }

        [TestMethod]
        public void Post()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }

        [TestMethod]
        public void Delete()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }
    }
}
