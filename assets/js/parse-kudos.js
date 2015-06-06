String.prototype.hashCode = function() {
    var hash = 0, i, chr, len;
    if (this.length === 0) return hash;
    for (i = 0, len = this.length; i < len; i++) {
        chr   = this.charCodeAt(i);
        hash  = ((hash << 5) - hash) + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return ''+hash;
};

function updateScore(score) {
    $("#kudo .num").html(score);
    if ( score == 1 ) {
        $("#kudo .txt").html('Like');
    } else {
        $("#kudo .txt").html('Likes');
    }
}

$(function(){
    Parse.initialize("Az7OeB7BabY5XBztiDmVOZ03MHZl3IlbHGQh028f", "CuDMF0OfRu6SmAjri99ltYGcdSIUIybfVoYgPG30");
    var Kudos = Parse.Object.extend("Kudos");
    var query = new Parse.Query(Kudos);

    $(".kudoable").kudoable();

    var key = document.location.pathname.hashCode();
    var title = $("article").attr("title");

    var kudo;

    query.equalTo("key", key);
    query.first({
        success: function(result) {
            kudo = result;
            if ( !kudo )
            {
                kudo = new Kudos();
                kudo.set("key", key);
                kudo.set("title", title);
                kudo.set("score", 0);
                kudo.save();
            }
            var score = kudo.get("score");
            if ( score <= 0 ) {
                $.removeCookie(key);
                $(".kudoable").removeClass("complete");
                kudo.set("score", 0);
                score = 0;
            }
            updateScore(score);
            if ( $.cookie(key) ) {
                $(".kudo").removeClass("animate").addClass("complete").addClass("new");
                updateScore(kudo.get("score"), kudo);
            }
        },
        error: function (error) {
            kudo = new Kudos();
            kudo.set("key", key);
            kudo.set("title", title);
            kudo.set("score", 0);
            kudo.save();
        }
    });

    $(".kudo").bind("kudo:added", function(e) {
        console.log("kudod :)");
        $.cookie(key, 'true', { expires: 28 });

        kudo.increment("score");
        kudo.save(null, {success: function(k) {
            updateScore(kudo.get("score"));
        }});

        ga('send', 'event', 'kudos', 'like', title, {'nonInteraction': 1});
    });

    $(".kudo").bind("kudo:removed", function(e) {
        console.log("Unkudod :(");
        $.removeCookie(key);
        $(".kudoable").removeClass("new");

        kudo.increment("score", -1);
        kudo.save(null, {success: function(k) {
            updateScore(kudo.get("score"));
        }});

        ga('send', 'event', 'kudos', 'unlike', title, {'nonInteraction': 1});
    });
});
