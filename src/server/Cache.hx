package;

/**
 * ...
 * @author TiagoLr
 */
class Cache {

	static var cache = { 
		rss : {articles : {}}
	};
	
	static public function setArticleRss(params:Dynamic, output:String) {
		var hash = 'articleRss' + Shared.utils.objectToHash(params);
		Reflect.setField(cache.rss.articles, hash, {val: output, ts: Date.now().getTime()});
	}
	
	static public function getArticleRss(params:Dynamic) {
		var hash = 'articleRss' + Shared.utils.objectToHash(params);
		var res = Reflect.field(cache.rss.articles, hash);
		
		if (res != null && (Date.now().getTime() - res.ts) < Configs.server.cache.rss_articles_ttl * 60 * 1000) {
			return res.val;
		}
		
		return null;
	}
	
}