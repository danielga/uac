--Come on Garry, what the fuck did you do to SNPCs? They don't have any of these functions clientside...
--Only some bone shit. And even those won't be replaced by this script.

include("shared.lua")

hook.Add("OnEntityCreated", "lemonade.OnEntityCreated", function(ent)
	if !ent or !ent:IsValid() then return end

	if ent:GetClass() == "lemonade" then
		ent.BuildBonePositions = function(self, NumBones, NumPhysBones)
			local BoneIndex = self:LookupBone("ValveBiped.Bip01_Head1")
			local BoneMatrix = self:GetBoneMatrix(BoneIndex)
			BoneMatrix:Scale(Vector(0.1, 0.1, 0.1))
			BoneMatrix:Translate(Vector(-100, 0, 0))
			self:SetBoneMatrix(BoneIndex, BoneMatrix)
		end

		ent.Expressions = {}
		ent.CurrentExpression = false

		function ent.AddExpression(self, name, tab)
			self.Expressions[name] = tab
		end

		function ent.SetCurrentExpression(self, name)
			self.CurrentExpression = self.Expressions[name]
		end

		local expression = {}

		expression.Face = {}
		expression.Face.color = Color(239, 208, 207, 255)
		expression.Face.x = 2
		expression.Face.y = 2
		expression.Face.width = 16
		expression.Face.height = 16

		expression.Hair = {}
		expression.Hair.color = Color(110, 50, 20, 255)
		expression.Hair.x = 2
		expression.Hair.y = 2
		expression.Hair.width = 16
		expression.Hair.height = 2

		expression.Eye1 = {}
		expression.Eye1.color = Color(255, 255, 255, 255)
		expression.Eye1.x = 4
		expression.Eye1.y = 7
		expression.Eye1.width = 4
		expression.Eye1.height = 4

		expression.Eye2 = {}
		expression.Eye2.color = Color(255, 255, 255, 255)
		expression.Eye2.x = 12
		expression.Eye2.y = 7
		expression.Eye2.width = 4
		expression.Eye2.height = 4

		expression.Iris1 = {}
		expression.Iris1.color = Color(0, 0, 0, 255)
		expression.Iris1.x = 5
		expression.Iris1.y = 8
		expression.Iris1.width = 2
		expression.Iris1.height = 2

		expression.Iris2 = {}
		expression.Iris2.color = Color(0, 0, 0, 255)
		expression.Iris2.x = 13
		expression.Iris2.y = 8
		expression.Iris2.width = 2
		expression.Iris2.height = 2

		expression.Lip1 = {}
		expression.Lip1.color = Color(120, 34, 34, 255)
		expression.Lip1.x = 6
		expression.Lip1.y = 12
		expression.Lip1.width = 8
		expression.Lip1.height = 2

		expression.Lip2 = {}
		expression.Lip2.color = Color(120, 34, 34, 255)
		expression.Lip2.x = 6
		expression.Lip2.y = 14
		expression.Lip2.width = 8
		expression.Lip2.height = 2

		expression.Mouth = {}
		expression.Mouth.color = Color(178, 34, 34, 255)
		expression.Mouth.x = 7
		expression.Mouth.y = 13
		expression.Mouth.width = 6
		expression.Mouth.height = 2

		ent:AddExpression("neutral", expression)
		ent:SetCurrentExpression("neutral")

		local index = ent:EntIndex()
		hook.Add("PostDrawTranslucentRenderables", "lemonade.PostDrawTranslucentRenderables." .. index, function()
			if !ent or !ent:IsValid() then
				hook.Remove("PostDrawTranslucentRenderables", "lemonade.PostDrawTranslucentRenderables." .. index)
				return
			end

			local BoneIndex = ent:LookupBone("ValveBiped.Bip01_Head1")
			local BonePos, BoneAng = ent:GetBonePosition(BoneIndex)
			local angle = BoneAng
			angle:RotateAroundAxis(BoneAng:Right(), -90)
			angle:RotateAroundAxis(BoneAng:Forward(), 90)
			cam.Start3D2D(BonePos + BoneAng:Forward() * -10 + BoneAng:Right() * -29 + BoneAng:Up() * 0, angle, 1)
				local part = ent.CurrentExpression.Face
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)

				part = ent.CurrentExpression.Hair
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)

				part = ent.CurrentExpression.Eye1
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)
				part = ent.CurrentExpression.Eye2
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)

				part = ent.CurrentExpression.Iris1
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)
				part = ent.CurrentExpression.Iris2
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)

				part = ent.CurrentExpression.Lip1
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)
				part = ent.CurrentExpression.Lip2
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)
				part = ent.CurrentExpression.Mouth
				surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
				surface.DrawRect(part.x, part.y, part.width, part.height)
			cam.End3D2D()
		end)
	end
end)

--[[

--language.Add("lemonade", "Lemonade")
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Expressions = {}
ENT.CurrentExpression = false
ENT.Started = false

function ENT:AddExpression(name, tab)
	self.Expressions[name] = tab
end

function ENT:SetCurrentExpression(name)
	self.CurrentExpression = self.Expressions[name]
end

local expression = {}

expression.Face = {}
expression.Face.color = Color(239, 208, 207, 255)
expression.Face.x = 2
expression.Face.y = 2
expression.Face.width = 16
expression.Face.height = 16

expression.Hair = {}
expression.Hair.color = Color(110, 50, 20, 255)
expression.Hair.x = 2
expression.Hair.y = 2
expression.Hair.width = 16
expression.Hair.height = 2

expression.Eye1 = {}
expression.Eye1.color = Color(255, 255, 255, 255)
expression.Eye1.x = 4
expression.Eye1.y = 7
expression.Eye1.width = 4
expression.Eye1.height = 4

expression.Eye2 = {}
expression.Eye2.color = Color(255, 255, 255, 255)
expression.Eye2.x = 12
expression.Eye2.y = 7
expression.Eye2.width = 4
expression.Eye2.height = 4

expression.Iris1 = {}
expression.Iris1.color = Color(0, 0, 0, 255)
expression.Iris1.x = 5
expression.Iris1.y = 8
expression.Iris1.width = 2
expression.Iris1.height = 2

expression.Iris2 = {}
expression.Iris2.color = Color(0, 0, 0, 255)
expression.Iris2.x = 13
expression.Iris2.y = 8
expression.Iris2.width = 2
expression.Iris2.height = 2

expression.Lip1 = {}
expression.Lip1.color = Color(120, 34, 34, 255)
expression.Lip1.x = 6
expression.Lip1.y = 12
expression.Lip1.width = 8
expression.Lip1.height = 2

expression.Lip2 = {}
expression.Lip2.color = Color(120, 34, 34, 255)
expression.Lip2.x = 6
expression.Lip2.y = 14
expression.Lip2.width = 8
expression.Lip2.height = 2

expression.Mouth = {}
expression.Mouth.color = Color(178, 34, 34, 255)
expression.Mouth.x = 7
expression.Mouth.y = 13
expression.Mouth.width = 6
expression.Mouth.height = 2

function ENT:Initialize()
	self:AddExpression("neutral", expression)
	self:SetCurrentExpression("neutral")
end

function ENT:Think()
	MsgN("Think")
	if !self.Started then
		self:AddExpression("neutral", expression)
		self:SetCurrentExpression("neutral")
		self.Started = true
	end
end

function ENT:Draw()
	MsgN("Draw")
	self:DrawModel()

	if !self.CurrentExpression and !self.Started then
		self:AddExpression("neutral", expression)
		self:SetCurrentExpression("neutral")
		self.Started = true
	end

	local BoneIndex = self:LookupBone("ValveBiped.Bip01_Head1")
	local BonePos, BoneAng = self:GetBonePosition(BoneIndex)
	local angle = BoneAng
	angle:RotateAroundAxis(BoneAng:Right(), -90)
	angle:RotateAroundAxis(BoneAng:Forward(), 90)
	cam.Start3D2D(BonePos + BoneAng:Forward() * -10 + BoneAng:Right() * -29 + BoneAng:Up() * 0, angle, 1)
		local part = self.CurrentExpression.Face
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)

		part = self.CurrentExpression.Hair
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)

		part = self.CurrentExpression.Eye1
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)
		part = self.CurrentExpression.Eye2
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)

		part = self.CurrentExpression.Iris1
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)
		part = self.CurrentExpression.Iris2
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)

		part = self.CurrentExpression.Lip1
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)
		part = self.CurrentExpression.Lip2
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)
		part = self.CurrentExpression.Mouth
		surface.SetDrawColor(part.color.r, part.color.g, part.color.b, part.color.a)
		surface.DrawRect(part.x, part.y, part.width, part.height)
	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:BuildBonePositions(NumBones, NumPhysBones)
	local BoneIndex = self:LookupBone("ValveBiped.Bip01_Head1")
	local BoneMatrix = self:GetBoneMatrix(BoneIndex)
	BoneMatrix:Scale(Vector(0.1, 0.1, 0.1))
	BoneMatrix:Translate(Vector(-100, 0, 0))
	self:SetBoneMatrix(BoneIndex, BoneMatrix)
end

function ENT:SetRagdollBones(bIn)
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone(PhysBoneNum, BoneNum)
//	self:SetBonePosition(BoneNum, Pos, Angle)
end

]]--