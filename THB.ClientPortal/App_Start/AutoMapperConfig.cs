using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using AutoMapper;
using Backend.Business.Entities;
using Shared.Business.DTOs;
using Frontend.Web.Extensions;
using Shared.Business.Contracts;

namespace Frontend.Web.App_Start
{
    public class AutoMapperConfig
    {
        public static void RegisterMappings()
        {
            Mapper.CreateMap<TaskEntity, TaskDTO>().IgnoreNonExistingProperties<TaskEntity, TaskDTO>();
            Mapper.CreateMap<TaskDTO, TaskEntity>().IgnoreNonExistingProperties<TaskDTO, TaskEntity>();
            Mapper.CreateMap<TaskEntity, TaskContract>().IgnoreNonExistingProperties<TaskEntity, TaskContract>();
            Mapper.CreateMap<TaskContract, TaskDTO>().IgnoreNonExistingProperties<TaskContract, TaskDTO>();
            Mapper.CreateMap<TaskDTO, TaskContract>().IgnoreNonExistingProperties<TaskDTO, TaskContract>();
            Mapper.CreateMap<ClientEntity, ClientDTO>().IgnoreNonExistingProperties<ClientEntity, ClientDTO>();
            Mapper.CreateMap<ClientDTO, ClientEntity>().IgnoreNonExistingProperties<ClientDTO, ClientEntity>();
            Mapper.CreateMap<TaskTypeEntity, TaskTypeDTO>().IgnoreNonExistingProperties<TaskTypeEntity, TaskTypeDTO>();
            Mapper.CreateMap<TaskTypeDTO, TaskTypeEntity>().IgnoreNonExistingProperties<TaskTypeDTO, TaskTypeEntity>();
           // Mapper.CreateMap<I_NEWS, TaskDTO>().ForMember(x => x.Date,
             //    opt => opt.MapFrom(src => ((DateTime)src.Date).ToShortDateString()));
        }
    }
}