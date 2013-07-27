$(function() {

    var upload = $('#direct-upload');
    var form = $(this).find('form');

    form.fileupload({
      url: form.attr('action'),
      type: 'POST',
      autoUpload: true,
      dataType: 'xml', // This is really important as s3 gives us back the url of the file in a XML document
      add: function (event, data) {
        $.ajax({
          url: "/signed_urls",
          type: 'GET',
          dataType: 'json',
          data: {doc: {title: data.files[0].name}}, // send the file name to the server so it can generate the key param
          async: false,
          success: function(data) {
            var form_copy = form.clone().data('key', data.key).appendTo(upload);

            // Now that we have our data, we update the form so it contains all
            // the needed data to sign the request
            form_copy.find('input[name=key]').val(data.key);
            form_copy.find('input[name=policy]').val(data.policy);
            form_copy.find('input[name=signature]').val(data.signature);
          }
        });
        data.submit();
      },
      send: function(e, data) {
        console.log("send");
        console.log(data);
      },
      progress: function(e, data){
        // This is what makes everything really cool, thanks to that callback
        // you can now update the progress bar based on the upload progress
        var percent = Math.round((e.loaded / e.total) * 100);
        $('form[data-key='+data.key+']').find('.bar').css('width', percent + '%');
      },
      fail: function(e, data) {
        console.log("fail");
        console.log(data);
      },
      success: function(data) {
        // Here we get the file url on s3 in an xml doc
        var url = $(data).find('Location').text();
        //TODO: something with the file
      },
      done: function (event, data) {
        $('form[data-key='+data.key+']').find('.bar').css('width', 0);
      }
    });

});