using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using AutoMapper;
using Backend.Business.Entities;
using Shared.Business.DTOs;
using Frontend.Web.Extensions;

namespace Frontend.Web.App_Start
{
    public class AutoMapperConfig
    {
        public static void RegisterMappings()
        {

            Mapper.CreateMap<TaskEntity, TaskDTO>().IgnoreNonExistingProperties<TaskEntity, TaskDTO>();
            Mapper.CreateMap<TaskDTO, TaskEntity>().IgnoreNonExistingProperties<TaskDTO, TaskEntity>();
        }
    }
}