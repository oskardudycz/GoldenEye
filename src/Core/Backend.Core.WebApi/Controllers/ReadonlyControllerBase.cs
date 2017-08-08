using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;
using GoldenEye.Backend.Core.Service;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.Frontend.Core.Web.Controllers
{
    public abstract class ReadonlyControllerBase<TService, TDto> : Controller 
        where TService : IReadonlyService<TDto> where TDto : class, IDTO
    {
        protected TService Service;

        protected ReadonlyControllerBase(TService service)
        {
            Service = service;
        }

        protected ReadonlyControllerBase()
        {
        }

        public virtual IQueryable<TDto> Get()
        {
            return Service.Get();
        }

        public async Task<IActionResult> Get(int id)
        {
            var dto = await Service.Get(id);
            if (dto == null)
            {
                return NotFound();
            }

            return Ok(dto);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                Service.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}