(function($, undefined) {

  $.fn.railsgrid = function(method) {
    if ( methods[method] ) {
      return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if (typeof(method) === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      $.error( 'Method ' + method + ' does not exist on jQuery.railsgrid' );
    }
  };

  var methods = {
    init : function(options){
      var settings = { 
        url       : "/", 
        name      : "", 
        query     : { 
          pagination : { page : 0, per_page : 20 }, 
          conditions : {},
          order      : {}
        },
        searchFadeTime  : 250,
        searchFadeOpac  : 0.5,
        queries : 0
      }
      options = (options || {});
      $.extend(settings, options);
      
      return this.each(function(){
        var $this = $(this);
        var data = $this.data('railsgrid');
        
        if (!data){
          // initialize railsgrid
          
          // set data
          $this.data('railsgrid', settings);
          
          // search attribute changed/focused
          $this.find(".js-attribute").bind("change.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('newSearch'); 
            return false;
          }).bind("focus.railsgrid", function(){
            $(this).select();
            return false;
          });
          
          // search attribute changed/focused
          $this.find(".js-page").bind("change.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('page', $(this).val()); 
            return false;
          }).bind("focus.railsgrid", function(){
            $(this).select();
            return false;
          });
          
          // previous page click
          $this.find(".js-previous").bind("click.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('previousPage'); 
            return false;
          });
          
          // next page click
          $this.find(".js-next").bind("click.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('nextPage'); 
            return false;
          });
          
          // reload click
          $this.find(".js-reload").bind("click.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('reloadPage'); 
            return false;
          });
          
          // clear click
          $this.find(".js-clear").bind("click.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('clearSearch'); 
            return false;
          });
          
          // clear click
          $this.find(".js-per-page").bind("change.railsgrid", function(){
            $(this).parents(".js-railsgrid").railsgrid('perPage', $(this).val()); 
            return false;
          });
        } else {
          $.extend(data, options);
        }
      });
    },
    destroy : function(){
      return this.each(function(){
        var $this = $(this);
        data = $this.data('railsgrid');
        $this.unbind('.railsgrid');
        $this.removeData('railsgrid');
      });
    },
    setupConditions : function(){
      var $this = $(this);
      var data = $this.data('railsgrid');
      
      data.query.conditions = {};
      $(this).find(".js-attribute").each(function(){
        data.query.conditions[$(this).attr("name")] = $(this).val();
      });
    },
    setupPagination : function(page, perPage){
      var $this = $(this);
      var data = $this.data('railsgrid');
      
      data.query.pagination = { page : 0, per_page : 20 };
      if(!isNaN(Number(page)) && Number(page) >= 0){
        data.query.pagination.page = page;
      }
      if (!isNaN(Number(perPage)) && Number(perPage) > 0){
        data.query.pagination.per_page = perPage;
      }
    },
    order : function(){
      return "";
    },
    search : function(){
      var $this = $(this);
      var $content = $this.find(".js-tablewrapper");
      var $control = $this.find(".js-tablecontrol");
      var data = $this.data('railsgrid');
      data.queries += 1;
      
      $control.find(".js-reload").addClass("loading");
      $this.fadeTo(data.searchFadeTime, data.searchFadeOpac);
      
      $.ajax({
        type      : "GET",
        url       : data.url,
        data      : data.query,
        dataType  : "html",
        success   : function(result){  
          data.queries -= 1;
          if(data.queries == 0){
            $content.find(".js-row").detach();
            $content.find("table").append($(result).find(".js-row"));
            $control.find(".js-per-page").val(data.query.pagination.per_page);
            $control.find(".js-page").val(Number(data.query.pagination.page) + 1);
            
            total = (Number($(result).find(".js-page-total").text()));
            totalPages = total / data.query.pagination.per_page
            totalPages = (totalPages | 0) + 1;

            $control.find(".js-page-total").text(totalPages);
            
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".js-reload").removeClass("loading");
            }); 
          }
        },
        error     : function(){
          data.queries -= 1;
          if(data.queries == 0){
            $content.find(".js-row").detach();
            $this.fadeTo(data.searchFadeTime, 1.0, function(){
              $control.find(".js-reload").removeClass("loading");
            });
          }
        }
      });
    },
    nextPage : function(){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", data.query.pagination.page + 1, data.query.pagination.per_page);
      $this.railsgrid("search");
    },
    previousPage : function(){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", data.query.pagination.page - 1, data.query.pagination.per_page);
      $this.railsgrid("search");
    },
    perPage : function(perPage){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", 0, perPage);
      $this.railsgrid("search");
    },
    page : function(page){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", Number(page) - 1, data.query.pagination.per_page);
      $this.railsgrid("search");
    },
    reloadPage : function(){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", data.query.pagination.page, data.query.pagination.per_page);
      $this.railsgrid("setupConditions");
      $this.railsgrid("search");
    },
    newSearch : function(){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.railsgrid("setupPagination", 0, data.query.pagination.per_page);
      $this.railsgrid("setupConditions");
      $this.railsgrid("search");
    },
    clearSearch : function(){
      var $this = $(this);
      data = $this.data('railsgrid');
      $this.find(".js-attribute").each(function(){
        $(this).val("");
      });
      $this.railsgrid("setupPagination", 0, data.query.pagination.per_page);
      $this.railsgrid("setupConditions");
      $this.railsgrid("search");
    },
    action : function(name, value){
      $(this).trigger("action_" + name, value);
    }
  };
})(jQuery);