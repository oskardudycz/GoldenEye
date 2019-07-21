using System.Threading.Tasks;
using GoldenEye.Backend.Core.Services;
using GoldenEye.Shared.Core.Objects.DTO;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.Frontend.Core.Web.Controllers
{
    public abstract class RestControllerBase<TService, TDto>: ReadonlyControllerBase<TService, TDto>
        where TDto : class, IDTO
        where TService : IRestService<TDto>
    {
        protected RestControllerBase(TService service) : base(service)
        {
        }

        protected RestControllerBase()
        {
        }

        public virtual async Task<IActionResult> Put(TDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.PutAsync(dto);

            return Ok(result);
        }

        public virtual async Task<IActionResult> Post(TDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.PostAsync(dto);

            return Ok(result);
        }

        public async Task<IActionResult> Delete(int id)
        {
            var wasDeleted = await Service.DeleteAsync(id);
            if (!wasDeleted)
            {
                return NotFound();
            }

            return Ok();
        }
    }
}
