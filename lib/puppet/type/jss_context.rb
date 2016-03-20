# lib/puppet/type/jss_context.rb
Puppet::Type.newtype(:jss_context) do
    @doc = %q{Creates a jss context. If you're lucky
    it will also create a database.

    Example:
        jss_context {'production':
            ensure => present,
            war => 'puppet:///modules/jss/ROOT.war',
        }
    }
    ensurable
    newproperty(:context) do
        desc "Context of the JSS environment."
    end

    newproperty(:firewall) do
        desc "State of the firewall on the JSS nodes."
    end
     newproperty(:firewall) do
        newvalue(:true)
        newvalue(:false)
    end

end
