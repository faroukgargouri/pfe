using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrikiApi.Data;
using TrikiApi.Models;

namespace TrikiApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")] // => génère /api/orders
    public class OrdersController : ControllerBase
    {
        private readonly TrikiDbContext _context;

        public OrdersController(TrikiDbContext context)
        {
            _context = context;
        }

        // GET: /api/orders/full
        [HttpGet("full")]
        public async Task<IActionResult> GetFullOrders()
        {
            try
            {
                var orders = await _context.Orders
                    .Include(o => o.User)
                    .Include(o => o.OrderItems)
                        .ThenInclude(oi => oi.Product)
                    .ToListAsync();

                var result = orders.Select(o => new
                {
                    orderId = o.Id,
                    client = o.User.FirstName + " " + o.User.LastName,
                    createdAt = o.CreatedAt,
                    total = o.Total,
                    items = o.OrderItems.Select(oi => new
                    {
                        productName = oi.Product.Name,
                        quantity = oi.Quantity,
                        unitPrice = oi.UnitPrice,
                        totalPrice = oi.TotalPrice
                    })
                });

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Erreur GetFullOrders: " + ex.Message);
                return StatusCode(500, new { message = "Erreur serveur", error = ex.Message });
            }
        }
    }
}
