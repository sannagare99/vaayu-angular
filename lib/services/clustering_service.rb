class ClusteringService
  include HTTParty
  base_uri ENV['CLUSTERING_SERVICE_URL']

  def self.auto_cluster(params)
    post('/api/clusters', { body: params.to_json })
  end
end
