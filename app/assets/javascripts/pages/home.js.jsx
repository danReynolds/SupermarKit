document.addEventListener('turbolinks:load', () => {
    onPage('pages home', () => {
        nav = $('nav');
        $(window).scroll(() => {
            $(document).scrollTop() === 0 ? nav.addClass('top') : nav.removeClass('top');
        });
        $(window).scroll();
    });
});
