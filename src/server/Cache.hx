package;

typedef CacheEntry = {
	val:Dynamic,
	ts:Float,
}

class Cache {

	static var cache = { 
		rss : { articles : {} },
		seo : { html: {}},
	};
	
	/************************************************
	 * RSS Cache
	 ************************************************/
	static public function setArticleRss(params:Dynamic, output:String) {
		var hash = 'articleRss' + SharedUtils.objectToHash(params);
		Reflect.setField(cache.rss.articles, hash, createEntry(output));
	}
	
	static public function getArticleRss(params:Dynamic) {
		var hash = 'articleRss' + SharedUtils.objectToHash(params);
		var res = Reflect.field(cache.rss.articles, hash);
		
		if (res != null && !hasExpired(res, Configs.server.cache.rss_articles_ttl)) {
			return res.val;
		}
		
		return null;
	}
	
	/************************************************
	 * SEO HTML Cache
	 ************************************************/
	static public function setSEOHtml(params:Dynamic,  html:String) {
		var hash = 'seoHtml' + SharedUtils.objectToHash(params);
		Reflect.setField(cache.seo.html, hash, createEntry(html));
	}
	
	static public function getSEOHtml(params:Dynamic):String {
		var hash = 'seoHtml' + SharedUtils.objectToHash(params);
		var res = Reflect.field(cache.seo.html, hash);
		
		if (res != null && !hasExpired(res, Configs.server.cache.seo_html_ttl)) {
			return res.val;
		}
		
		return null;
	}
	
	/************************************************
	 * Aux
	 ************************************************/
	static function createEntry(val:Dynamic):CacheEntry {
		return {
			val:val,
			ts: Date.now().getTime(),
		}
	}
	
	static function hasExpired(entry:CacheEntry, ttl_mnts:Int) {
		return Date.now().getTime() - entry.ts > ttl_mnts * 60 * 1000;
	}
}