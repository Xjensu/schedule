import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.initNavigation();
  }

  initNavigation() {
    const $ = jQuery;
    console.log("Navigation initialized");
    
    // browser window scroll (in pixels) after which the "menu" link is shown
    var offset = 0;

    var navigationContainer = $('#cd-nav'),
        mainNavigation = navigationContainer.find('#cd-main-nav ul');

    // Hide or show the "menu" link
    this.checkMenu();
    $(window).scroll(() => {
      this.checkMenu();
    });

    // Open or close the menu clicking on the bottom "menu" link
    $('.cd-nav-trigger').on('click', (e) => {
      e.preventDefault();
      $(e.currentTarget).toggleClass('menu-is-open');
      mainNavigation.off('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend').toggleClass('is-visible');
    });

    // Reinitialize on Turbo events
    document.addEventListener("turbo:load", () => {
      this.checkMenu();
    });

    document.addEventListener("turbo:render", () => {
      this.checkMenu();
    });
  }

  checkMenu() {
    const $ = jQuery;
    var offset = -1;
    var navigationContainer = $('#cd-nav');
    var mainNavigation = navigationContainer.find('#cd-main-nav ul');

    if ($(window).scrollTop() > offset && !navigationContainer.hasClass('is-fixed')) {
      navigationContainer.addClass('is-fixed').find('.cd-nav-trigger').one('webkitAnimationEnd oanimationend msAnimationEnd animationend', function(){
        mainNavigation.addClass('has-transitions');
      });
    } else if ($(window).scrollTop() <= offset) {
      if (mainNavigation.hasClass('is-visible') && !$('html').hasClass('no-csstransitions')) {
        mainNavigation.addClass('is-hidden').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
          mainNavigation.removeClass('is-visible is-hidden has-transitions');
          navigationContainer.removeClass('is-fixed');
          $('.cd-nav-trigger').removeClass('menu-is-open');
        });
      } else if (mainNavigation.hasClass('is-visible') && $('html').hasClass('no-csstransitions')) {
        mainNavigation.removeClass('is-visible has-transitions');
        navigationContainer.removeClass('is-fixed');
        $('.cd-nav-trigger').removeClass('menu-is-open');
      } else {
        navigationContainer.removeClass('is-fixed');
        mainNavigation.removeClass('has-transitions');
      }
    }
  }
}