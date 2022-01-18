plan vmware_tasks::pdb_test {
  return(puppetdb_query('nodes[certname] {}'))
}
