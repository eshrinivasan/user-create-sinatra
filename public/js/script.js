 $(document).ready(function(){
    var voteId, votedForm, voteAction, voteList = [];

    
    $(document).on('click', '#submit', function(e){
        votedForm = $(this).parent('form');
        voteAction = $(this).parent('form').attr('action');
        voteId = voteAction.split('/').pop();
        if(voteList.indexOf(voteId) === -1)
        voteList.push(voteId);
        //console.log(voteList);
        
        $.ajax({
            url: voteAction,
            type: "POST"
        }).done(function(data,text,jQxhr){
           var result = JSON.parse(data);
           votedForm.find('.button').attr('disabled', true)
           if(typeof result === 'object' && result != null)
            votedForm.find('.points').text(result.points);
        });
    });


    $(document).on('click', '#user', function(e){
        voteAction = $(this).parent('form').attr('action');
        console.log(voteAction);
        $.ajax({
            url: voteAction,
            type: "POST",
            data: {id: ID()}
        }).done(function(data,text,jQxhr){
           //var result = JSON.parse(data);
           console.log(data);
        });
    });

    $(document).on('click', '#download', function(e){
        voteAction = $(this).parent('form').attr('action');
        console.log(voteAction);
        $.ajax({
            url: voteAction,
            type: "POST"
        }).done(function(data,text,jQxhr){
           //var result = JSON.parse(data);
           console.log(data);
        });
    });

});

Storage.prototype.setObject = function(key, value) {
    this.setItem(key, JSON.stringify(value));
}

Storage.prototype.getObject = function(key) {
    var value = this.getItem(key);
    return value && JSON.parse(value);
}

