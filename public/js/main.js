async function addToCart(productId, quantity = 1) {
    try {
        const response = await fetch('/cart/add', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ product_id: productId, quantity }),
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Product added to cart!', 'success');
            updateCartBadge(data.cartCount);
        } else {
            showNotification('Error adding product to cart', 'error');
        }
    } catch (err) {
        console.error(err);
        showNotification('Error adding product to cart', 'error');
    }
}

async function updateCartQuantity(cartId, quantity) {
    try {
        const response = await fetch('/cart/update', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cart_id: cartId, quantity }),
        });
        const data = await response.json();
        if (data.success) {
            updateCartBadge(data.cartCount);
            location.reload();
        }
    } catch (err) {
        console.error(err);
    }
}

async function removeFromCart(cartId) {
    if (!confirm('Remove this item from cart?')) return;
    try {
        const response = await fetch('/cart/remove', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cart_id: cartId }),
        });
        const data = await response.json();
        if (data.success) {
            updateCartBadge(data.cartCount);
            location.reload();
        }
    } catch (err) {
        console.error(err);
    }
}

function updateCartBadge(count) {
    const badge = document.querySelector('.cart-badge');
    if (!badge) return;
    badge.textContent = count;
    badge.style.display = count > 0 ? 'inline-block' : 'none';
}

function showNotification(message, type = 'success') {
    const existing = document.querySelector('.notification-toast');
    if (existing) existing.remove();

    const notification = document.createElement('div');
    notification.className = 'notification-toast';
    notification.innerHTML = message;

    notification.style.position = 'fixed';
    notification.style.top = '100px';
    notification.style.right = '30px';
    notification.style.padding = '20px 36px';
    notification.style.background = type === 'error' ? '#dc3545' : '#d4af37';
    notification.style.color = type === 'error' ? '#fff' : '#2c2c2c';
    notification.style.borderRadius = '8px';
    notification.style.boxShadow = '0 4px 16px rgba(0,0,0,.25)';
    notification.style.zIndex = '100000';
    notification.style.fontWeight = 'bold';
    notification.style.fontSize = '1rem';
    notification.style.transition = 'transform 1.5s cubic-bezier(.45,1.5,.44,1), opacity 1.5s';
    notification.style.transform = 'translateX(400px)';
    notification.style.opacity = '0';
    notification.style.minWidth = '230px';
    notification.style.textAlign = 'center';
    notification.style.fontFamily = 'inherit';

    document.body.appendChild(notification);
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
        notification.style.opacity = '1';
    }, 10);
    setTimeout(() => {
        notification.style.transform = 'translateX(400px)';
        notification.style.opacity = '0';
        setTimeout(() => {
            if (notification.parentNode) notification.parentNode.removeChild(notification);
        }, 1500);
    }, 2010);
}
