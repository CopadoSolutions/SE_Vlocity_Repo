vlocity.cardframework.registerModule.filter('formatDate', function() { 

    return function(input, format) {
        return moment(input).format(format);
    };
    }
);