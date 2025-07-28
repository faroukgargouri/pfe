using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TrikiApi.Data;
using TrikiApi.Dtos;
using TrikiApi.Models;

namespace TrikiApi.Controllers;


[ApiController]
[Route("api/[controller]")]
public class CartController : ControllerBase
{
    private readonly TrikiDbContext _context;
    public CartController(TrikiDbContext context) => _context = context;

    [HttpPost]
    public async Task<IActionResult> AddToCart([FromBody] CartItem item)
    {
        var existing = await _context.CartItems
            .FirstOrDefaultAsync(c => c.ProductId == item.ProductId && c.UserId == item.UserId);
        if (existing != null)
        {
            existing.Quantity += item.Quantity;
        }
        else
        {
            _context.CartItems.Add(item);
        }
        await _context.SaveChangesAsync();
        return Ok();
    }

    [HttpGet("{userId}")]
    public async Task<IActionResult> GetCart(int userId)
    {
        var cart = await _context.CartItems
            .Include(c => c.Product)
            .Where(c => c.UserId == userId)
            .ToListAsync();
        return Ok(cart);
    }
}
