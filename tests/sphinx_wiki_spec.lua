describe("sphinx-wiki", function()
	before_each(function()

		-- require"stackmap"._clear()
	end)

	it("can be required", function()
		require("sphinx-wiki")
	end)
	it("can be setup", function()
		require("sphinx-wiki").setup()
		assert.are.same(vim.fn.exists(":Wiki"), 2)
	end)
	it("requires environment variables", function()
		vim.cmd([[
        unlet $VIMWIKI
        ]])
		local err, _ = pcall(require, "sphinx-wiki.utils")
		assert.are.same(err, false)
	end)
end)
