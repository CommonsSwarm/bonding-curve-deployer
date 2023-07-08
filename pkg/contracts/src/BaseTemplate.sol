pragma solidity 0.6.2;

interface IFIFSResolvingRegistrar {
    function register(bytes32 _subnode, address _owner) external;
    function registerWithResolver(bytes32 _subnode, address _owner, address _resolver) external;
}

interface Agent {
    function initialize() external;
    function EXECUTE_ROLE() external returns (bytes32);
    function RUN_SCRIPT_ROLE() external returns (bytes32);
    function TRANSFER_ROLE() external returns (bytes32);
}

interface Vault {
    function initialize() external;
    function TRANSFER_ROLE() external returns (bytes32);
}

interface Voting {
    function initialize(address _token, uint64 _support, uint64 _minAcceptanceQuorum, uint64 _voteDuration) external;
    function CREATE_VOTES_ROLE() external returns (bytes32);
    function MODIFY_QUORUM_ROLE() external returns (bytes32);
    function MODIFY_SUPPORT_ROLE() external returns (bytes32);
}

interface Finance {
    function initialize(address _token, uint256 _periodDuration, uint256 _initialPeriod) external;
    function CREATE_PAYMENTS_ROLE() external returns (bytes32);
    function EXECUTE_PAYMENTS_ROLE() external returns (bytes32);
    function MANAGE_PAYMENTS_ROLE() external returns (bytes32);
}

interface TokenManager {
    function initialize(address _token, bool _transferable, uint256 _maxAccountTokens) external;
    function MINT_ROLE() external returns (bytes32);
    function BURN_ROLE() external returns (bytes32);
    function mint(address _tokenHolder, uint256 _amount) external;
    function burn(address _tokenHolder, uint256 _amount) external;
}

interface MiniMeTokenFactory {
    function createCloneToken(
        MiniMeToken _parentToken,
        uint256 _snapshotBlock,
        string calldata _tokenName,
        uint8 _decimalUnits,
        string calldata _tokenSymbol,
        bool _transfersEnabled
    ) external returns (MiniMeToken);
}

interface MiniMeToken {
    function changeController(address _newController) external;
}

interface ACL {
    function createPermission(address _entity, address _app, bytes32 _role, address _manager) external;
    function grantPermission(address _entity, address _app, bytes32 _role) external;
    function revokePermission(address _entity, address _app, bytes32 _role) external;
    function setPermissionManager(address _manager, address _app, bytes32 _role) external;
    function removePermissionManager(address _app, bytes32 _role) external;
    function CREATE_PERMISSIONS_ROLE() external returns (bytes32);
    function getEVMScriptRegistry() external view returns (EVMScriptRegistry);
}

interface Repo {
    function getLatest()
        external
        view
        returns (uint16[3] memory semanticVersion, address contractAddress, bytes memory contentURI);
}

interface DAOFactory {
    function newDAO(address _root) external returns (Kernel dao);
}

interface EVMScriptRegistry {
    function REGISTRY_MANAGER_ROLE() external returns (bytes32);
    function REGISTRY_ADD_EXECUTOR_ROLE() external returns (bytes32);
}

interface Kernel {
    function acl() external view returns (ACL);
    function APP_MANAGER_ROLE() external returns (bytes32);
    function setRecoveryVaultAppId(bytes32 _id) external;
    function newAppInstance(bytes32 _appId, address _appBase, bytes calldata _initializeData, bool _default)
        external
        returns (address);
}

interface ENS {
    function resolver(bytes32 _node) external view returns (PublicResolver);
}

interface PublicResolver {
    function addr(bytes32 _node) external view returns (address);
}

library Uint256Helpers {
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

contract APMNamehash {
    /* Hardcoded constants to save gas
    bytes32 internal constant APM_NODE = keccak256(abi.encodePacked(ETH_TLD_NODE, keccak256(abi.encodePacked("aragonpm"))));
    */
    bytes32 internal constant APM_NODE = 0x9065c3e7f7b7ef1ef4e53d2d0b8e0cef02874ab020c1ece79d5f0d3d0111c0ba;

    function apmNamehash(string memory name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(APM_NODE, keccak256(bytes(name))));
    }
}

contract TokenCache {
    string private constant ERROR_MISSING_TOKEN_CACHE = "TEMPLATE_MISSING_TOKEN_CACHE";

    mapping(address => address) internal tokenCache;

    function _cacheToken(MiniMeToken _token, address _owner) internal {
        tokenCache[_owner] = address(_token);
    }

    function _popTokenCache(address _owner) internal returns (MiniMeToken) {
        require(tokenCache[_owner] != address(0), ERROR_MISSING_TOKEN_CACHE);

        MiniMeToken token = MiniMeToken(tokenCache[_owner]);
        delete tokenCache[_owner];
        return token;
    }
}

contract IsContract {
    /*
    * NOTE: this should NEVER be used for authentication
    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).
    *
    * This is only intended to be used as a sanity check that an address is actually a contract,
    * RATHER THAN an address not being a contract.
    */
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly {
            size := extcodesize(_target)
        }
        return size > 0;
    }
}

abstract contract BaseTemplate is APMNamehash, IsContract {
    using Uint256Helpers for uint256;

    /* Hardcoded constant to save gas
    * bytes32 constant internal AGENT_APP_ID = apmNamehash("agent");                  // agent.aragonpm.eth
    * bytes32 constant internal VAULT_APP_ID = apmNamehash("vault");                  // vault.aragonpm.eth
    * bytes32 constant internal VOTING_APP_ID = apmNamehash("voting");                // voting.aragonpm.eth
    * bytes32 constant internal FINANCE_APP_ID = apmNamehash("finance");              // finance.aragonpm.eth
    * bytes32 constant internal TOKEN_MANAGER_APP_ID = apmNamehash("token-manager");  // token-manager.aragonpm.eth
    */
    bytes32 internal constant AGENT_APP_ID = 0x9ac98dc5f995bf0211ed589ef022719d1487e5cb2bab505676f0d084c07cf89a;
    bytes32 internal constant VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
    bytes32 internal constant VOTING_APP_ID = 0x9fa3927f639745e587912d4b0fea7ef9013bf93fb907d29faeab57417ba6e1d4;
    bytes32 internal constant FINANCE_APP_ID = 0xbf8491150dafc5dcaee5b861414dca922de09ccffa344964ae167212e8c673ae;
    bytes32 internal constant TOKEN_MANAGER_APP_ID = 0x6b20a3010614eeebf2138ccec99f028a61c811b3b1a3343b6ff635985c75c91f;

    string private constant ERROR_ENS_NOT_CONTRACT = "TEMPLATE_ENS_NOT_CONTRACT";
    string private constant ERROR_DAO_FACTORY_NOT_CONTRACT = "TEMPLATE_DAO_FAC_NOT_CONTRACT";
    string private constant ERROR_ARAGON_ID_NOT_PROVIDED = "TEMPLATE_ARAGON_ID_NOT_PROVIDED";
    string private constant ERROR_ARAGON_ID_NOT_CONTRACT = "TEMPLATE_ARAGON_ID_NOT_CONTRACT";
    string private constant ERROR_MINIME_FACTORY_NOT_PROVIDED = "TEMPLATE_MINIME_FAC_NOT_PROVIDED";
    string private constant ERROR_MINIME_FACTORY_NOT_CONTRACT = "TEMPLATE_MINIME_FAC_NOT_CONTRACT";
    string private constant ERROR_CANNOT_CAST_VALUE_TO_ADDRESS = "TEMPLATE_CANNOT_CAST_VALUE_TO_ADDRESS";
    string private constant ERROR_INVALID_ID = "TEMPLATE_INVALID_ID";

    ENS internal ens;
    DAOFactory internal daoFactory;
    MiniMeTokenFactory internal miniMeFactory;
    IFIFSResolvingRegistrar internal aragonID;

    event DeployDao(address dao);
    event SetupDao(address dao);
    event DeployToken(address token);
    event InstalledApp(address appProxy, bytes32 appId);

    constructor(DAOFactory _daoFactory, ENS _ens, MiniMeTokenFactory _miniMeFactory, IFIFSResolvingRegistrar _aragonID)
        public
    {
        require(isContract(address(_ens)), ERROR_ENS_NOT_CONTRACT);
        require(isContract(address(_daoFactory)), ERROR_DAO_FACTORY_NOT_CONTRACT);

        ens = _ens;
        aragonID = _aragonID;
        daoFactory = _daoFactory;
        miniMeFactory = _miniMeFactory;
    }

    /**
     * @dev Create a DAO using the DAO Factory and grant the template root permissions so it has full
     *      control during setup. Once the DAO setup has finished, it is recommended to call the
     *      `_transferRootPermissionsFromTemplateAndFinalizeDAO()` helper to transfer the root
     *      permissions to the end entity in control of the organization.
     */
    function _createDAO() internal returns (Kernel dao, ACL acl) {
        dao = daoFactory.newDAO(address(this));
        emit DeployDao(address(dao));
        acl = ACL(dao.acl());
        _createPermissionForTemplate(acl, address(dao), dao.APP_MANAGER_ROLE());
    }

    /* ACL */

    function _createPermissions(
        ACL _acl,
        address[] memory _grantees,
        address _app,
        bytes32 _permission,
        address _manager
    ) internal {
        _acl.createPermission(_grantees[0], _app, _permission, address(this));
        for (uint256 i = 1; i < _grantees.length; i++) {
            _acl.grantPermission(_grantees[i], _app, _permission);
        }
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }

    function _createPermissionForTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.createPermission(address(this), _app, _permission, address(this));
    }

    function _removePermissionFromTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.revokePermission(address(this), _app, _permission);
        _acl.removePermissionManager(_app, _permission);
    }

    function _transferRootPermissionsFromTemplateAndFinalizeDAO(Kernel _dao, address _to) internal {
        _transferRootPermissionsFromTemplateAndFinalizeDAO(_dao, _to, _to);
    }

    function _transferRootPermissionsFromTemplateAndFinalizeDAO(Kernel _dao, address _to, address _manager) internal {
        ACL _acl = ACL(_dao.acl());
        _transferPermissionFromTemplate(_acl, address(_dao), _to, _dao.APP_MANAGER_ROLE(), _manager);
        _transferPermissionFromTemplate(_acl, address(_acl), _to, _acl.CREATE_PERMISSIONS_ROLE(), _manager);
        emit SetupDao(address(_dao));
    }

    function _transferPermissionFromTemplate(ACL _acl, address _app, address _to, bytes32 _permission, address _manager)
        internal
    {
        _acl.grantPermission(_to, _app, _permission);
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }

    /* AGENT */

    function _installDefaultAgentApp(Kernel _dao) internal returns (Agent) {
        bytes memory initializeData = abi.encodeWithSelector(Agent(0).initialize.selector);
        Agent agent = Agent(_installDefaultApp(_dao, AGENT_APP_ID, initializeData));
        // We assume that installing the Agent app as a default app means the DAO should have its
        // Vault replaced by the Agent. Thus, we also set the DAO's recovery app to the Agent.
        _dao.setRecoveryVaultAppId(AGENT_APP_ID);
        return agent;
    }

    function _installNonDefaultAgentApp(Kernel _dao) internal returns (Agent) {
        bytes memory initializeData = abi.encodeWithSelector(Agent(0).initialize.selector);
        return Agent(_installNonDefaultApp(_dao, AGENT_APP_ID, initializeData));
    }

    function _createAgentPermissions(ACL _acl, Agent _agent, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, address(_agent), _agent.EXECUTE_ROLE(), _manager);
        _acl.createPermission(_grantee, address(_agent), _agent.RUN_SCRIPT_ROLE(), _manager);
    }

    /* VAULT */

    function _installVaultApp(Kernel _dao) internal returns (Vault) {
        bytes memory initializeData = abi.encodeWithSelector(Vault(0).initialize.selector);
        return Vault(_installDefaultApp(_dao, VAULT_APP_ID, initializeData));
    }

    function _createVaultPermissions(ACL _acl, Vault _vault, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, address(_vault), _vault.TRANSFER_ROLE(), _manager);
    }

    /* VOTING */

    function _installVotingApp(Kernel _dao, MiniMeToken _token, uint64[3] memory _votingSettings)
        internal
        returns (Voting)
    {
        return _installVotingApp(_dao, _token, _votingSettings[0], _votingSettings[1], _votingSettings[2]);
    }

    function _installVotingApp(Kernel _dao, MiniMeToken _token, uint64 _support, uint64 _acceptance, uint64 _duration)
        internal
        returns (Voting)
    {
        bytes memory initializeData =
            abi.encodeWithSelector(Voting(0).initialize.selector, _token, _support, _acceptance, _duration);
        return Voting(_installNonDefaultApp(_dao, VOTING_APP_ID, initializeData));
    }

    function _createVotingPermissions(
        ACL _acl,
        Voting _voting,
        address _settingsGrantee,
        address _createVotesGrantee,
        address _manager
    ) internal {
        _acl.createPermission(_settingsGrantee, address(_voting), _voting.MODIFY_QUORUM_ROLE(), _manager);
        _acl.createPermission(_settingsGrantee, address(_voting), _voting.MODIFY_SUPPORT_ROLE(), _manager);
        _acl.createPermission(_createVotesGrantee, address(_voting), _voting.CREATE_VOTES_ROLE(), _manager);
    }

    /* FINANCE */

    function _installFinanceApp(Kernel _dao, Vault _vault, uint64 _periodDuration) internal returns (Finance) {
        bytes memory initializeData = abi.encodeWithSelector(Finance(0).initialize.selector, _vault, _periodDuration);
        return Finance(_installNonDefaultApp(_dao, FINANCE_APP_ID, initializeData));
    }

    function _createFinancePermissions(ACL _acl, Finance _finance, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, address(_finance), _finance.EXECUTE_PAYMENTS_ROLE(), _manager);
        _acl.createPermission(_grantee, address(_finance), _finance.MANAGE_PAYMENTS_ROLE(), _manager);
    }

    function _createFinanceCreatePaymentsPermission(ACL _acl, Finance _finance, address _grantee, address _manager)
        internal
    {
        _acl.createPermission(_grantee, address(_finance), _finance.CREATE_PAYMENTS_ROLE(), _manager);
    }

    function _grantCreatePaymentPermission(ACL _acl, Finance _finance, address _to) internal {
        _acl.grantPermission(_to, address(_finance), _finance.CREATE_PAYMENTS_ROLE());
    }

    function _transferCreatePaymentManagerFromTemplate(ACL _acl, Finance _finance, address _manager) internal {
        _acl.setPermissionManager(_manager, address(_finance), _finance.CREATE_PAYMENTS_ROLE());
    }

    /* TOKEN MANAGER */

    function _installTokenManagerApp(Kernel _dao, MiniMeToken _token, bool _transferable, uint256 _maxAccountTokens)
        internal
        returns (TokenManager)
    {
        TokenManager tokenManager = TokenManager(_installNonDefaultApp(_dao, TOKEN_MANAGER_APP_ID));
        _token.changeController(address(tokenManager));
        tokenManager.initialize(address(_token), _transferable, _maxAccountTokens);
        return tokenManager;
    }

    function _createTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, address _grantee, address _manager)
        internal
    {
        _acl.createPermission(_grantee, address(_tokenManager), _tokenManager.MINT_ROLE(), _manager);
        _acl.createPermission(_grantee, address(_tokenManager), _tokenManager.BURN_ROLE(), _manager);
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] memory _holders, uint256[] memory _stakes)
        internal
    {
        _createPermissionForTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stakes[i]);
        }
        _removePermissionFromTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] memory _holders, uint256 _stake) internal {
        _createPermissionForTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stake);
        }
        _removePermissionFromTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address _holder, uint256 _stake) internal {
        _createPermissionForTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
        _tokenManager.mint(_holder, _stake);
        _removePermissionFromTemplate(_acl, address(_tokenManager), _tokenManager.MINT_ROLE());
    }

    /* EVM SCRIPTS */

    function _createEvmScriptsRegistryPermissions(ACL _acl, address _grantee, address _manager) internal {
        EVMScriptRegistry registry = EVMScriptRegistry(_acl.getEVMScriptRegistry());
        _acl.createPermission(_grantee, address(registry), registry.REGISTRY_MANAGER_ROLE(), _manager);
        _acl.createPermission(_grantee, address(registry), registry.REGISTRY_ADD_EXECUTOR_ROLE(), _manager);
    }

    /* APPS */

    function _installNonDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installNonDefaultApp(_dao, _appId, new bytes(0));
    }

    function _installNonDefaultApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData)
        internal
        returns (address)
    {
        return _installApp(_dao, _appId, _initializeData, false);
    }

    function _installDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installDefaultApp(_dao, _appId, new bytes(0));
    }

    function _installDefaultApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData) internal returns (address) {
        return _installApp(_dao, _appId, _initializeData, true);
    }

    function _installApp(Kernel _dao, bytes32 _appId, bytes memory _initializeData, bool _setDefault)
        internal
        returns (address)
    {
        address latestBaseAppAddress = _latestVersionAppBase(_appId);
        address instance = address(_dao.newAppInstance(_appId, latestBaseAppAddress, _initializeData, _setDefault));
        emit InstalledApp(instance, _appId);
        return instance;
    }

    function _latestVersionAppBase(bytes32 _appId) internal view returns (address base) {
        Repo repo = Repo(PublicResolver(ens.resolver(_appId)).addr(_appId));
        (, base,) = repo.getLatest();
    }

    /* TOKEN */

    function _createToken(string memory _name, string memory _symbol, uint8 _decimals) internal returns (MiniMeToken) {
        require(address(miniMeFactory) != address(0), ERROR_MINIME_FACTORY_NOT_PROVIDED);
        MiniMeToken token = miniMeFactory.createCloneToken(MiniMeToken(address(0)), 0, _name, _decimals, _symbol, true);
        emit DeployToken(address(token));
        return token;
    }

    function _ensureMiniMeFactoryIsValid(address _miniMeFactory) internal view {
        require(isContract(address(_miniMeFactory)), ERROR_MINIME_FACTORY_NOT_CONTRACT);
    }

    /* IDS */

    function _validateId(string memory _id) internal pure {
        require(bytes(_id).length > 0, ERROR_INVALID_ID);
    }

    function _registerID(string memory _name, address _owner) internal {
        require(address(aragonID) != address(0), ERROR_ARAGON_ID_NOT_PROVIDED);
        aragonID.register(keccak256(abi.encodePacked(_name)), _owner);
    }

    function _ensureAragonIdIsValid(address _aragonID) internal view {
        require(isContract(address(_aragonID)), ERROR_ARAGON_ID_NOT_CONTRACT);
    }

    /* HELPERS */

    function _toAddress(uint256 _value) private pure returns (address) {
        require(_value <= uint160(-1), ERROR_CANNOT_CAST_VALUE_TO_ADDRESS);
        return address(_value);
    }
}
