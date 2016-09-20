class OdataConfig

  def self.odata_config
    @odata_config ||= YAML.load_file(Rails.root.join('config', 'odata.yml'))
  end

end
