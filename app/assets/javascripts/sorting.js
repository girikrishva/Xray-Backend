function sorting_table(table)
  {
    $('th')
        .wrapInner('')
        .each(function(){
            
            var th = $(this),
                thIndex = th.index(),
                inverse = false;
            
            th.click(function(){
                if ((jQuery.inArray("sort_up",$(this).attr('class').split(" ")))== 1)
                    {
                        table.find('th').removeClass('sort_down')
                        table.find('th').addClass('sort_up')
                        $(this).removeClass('sort_up')
                        $(this).addClass('sort_down')
                    }
                else if ((jQuery.inArray("sort_down",$(this).attr('class').split(" ")))== 1){
                        $(this).removeClass('sort_down')
                        $(this).addClass('sort_up')
                    }

                table.find('td').filter(function(){
                    
                    return $(this).index() === thIndex;
                    
                }).sortElements(function(a, b){
                    if ($.text([a]).indexOf("₹") == 0){
                        return parseInt($.text([a]).replace(/[^\d.]/g, '')) > parseInt($.text([b]).replace(/[^\d.]/g, '')) ?
                        inverse ? -1 : 1
                        : inverse ? 1 : -1;
                    }
                    if($.isNumeric($.text([a]))){
                        return parseInt($.text([a])) > parseInt($.text([b])) ?
                        inverse ? -1 : 1
                        : inverse ? 1 : -1;
                    }
                    else{
                    return $.text([a]) > $.text([b]) ?
                        inverse ? -1 : 1
                        : inverse ? 1 : -1;
                    
                }}, function(){
                    return this.parentNode; 
                    
                });
                
                inverse = !inverse;
                    
            });
                
        });

  }
jQuery.fn.sortElements = (function(){
    
    var sort = [].sort;
        return function(comparator, getSortable) {
        
        getSortable = getSortable || function(){return this;};
        
        var placements = this.map(function(){
            
            var sortElement = getSortable.call(this),
                parentNode = sortElement.parentNode,
                
                // Since the element itself will change position, we have
                // to have some way of storing it's original position in
                // the DOM. The easiest way is to have a 'flag' node:
                nextSibling = parentNode.insertBefore(
                    document.createTextNode(''),
                    sortElement.nextSibling
                );
            
            return function() {
                
                if (parentNode === this) {
                    throw new Error(
                        "You can't sort elements if any one is a descendant of another."
                    );
                }
                
                // Insert before flag:
                parentNode.insertBefore(this, nextSibling);
                // Remove flag:
                parentNode.removeChild(nextSibling);
                
            };
            
        });
       
        return sort.call(this, comparator).each(function(i){
            placements[i].call(getSortable.call(this));
        });
        
    };
    
})();

