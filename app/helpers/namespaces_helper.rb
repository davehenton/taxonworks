module NamespacesHelper

  def self.namespace_tag(namespace)
    return nil if namespace.nil?
    namespace.name
  end

  def namespace_tag(namespace)
    NamespacesHelper.namespace_tag(namespace)
  end

  def namespace_link(namespace)
    return nil if namespace.nil?
    link_to(NamespacesHelper.namespace_tag(namespace).html_safe, namespace)
  end

  def namespaces_search_form
    render('/namespaces/quick_search_form')
  end

end
