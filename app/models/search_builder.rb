class SearchBuilder < CurationConcerns::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:hide_parented_resources, :join_from_parent]

  def self.show_actions
    [:show, :manifest, :structure, :pdf]
  end

  def hide_parented_resources(solr_params)
    return if show_action? || bulk_edit?
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{ActiveFedora::SolrQueryBuilder.solr_name('ordered_by', :symbol)}:['' TO *]"
  end

  def join_from_parent(solr_params)
    return if show_action?
    solr_params[:q] = JoinChildrenQuery.new(solr_params[:q]).to_s
  end

  def show_action?
    self.class.show_actions.include? blacklight_params["action"].to_sym
  end

  def bulk_edit?
    blacklight_params["action"].to_sym == :bulk_edit
  end
end
